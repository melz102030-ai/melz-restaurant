((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,A,C={
cbG(d){return new C.xX(d,null)},
xX:function xX(d,e){this.d=d
this.a=e},
A9:function A9(d,e){this.a=d
this.b=e
this.c=!1},
Zs:function Zs(d,e,f,g,h,i){var _=this
_.w=$
_.x=d
_.y=0.5
_.z=e
_.Q=f
_.ax=_.at=_.as=0
_.ch=_.ay=!1
_.CW=g
_.f1$=h
_.cl$=i
_.d=$
_.c=_.a=null},
bp_:function bp_(d,e){this.a=d
this.b=e},
bp1:function bp1(){},
bp2:function bp2(){},
boZ:function boZ(d,e){this.a=d
this.b=e},
bp0:function bp0(d){this.a=d},
bp5:function bp5(d){this.a=d},
bp6:function bp6(d,e){this.a=d
this.b=e},
bp4:function bp4(d){this.a=d},
bp3:function bp3(d,e){this.a=d
this.b=e},
aqm:function aqm(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bp7:function bp7(d,e){this.a=d
this.b=e},
Md:function Md(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
btK:function btK(d,e){this.a=d
this.b=e},
asv:function asv(d,e){this.c=d
this.a=e},
bud:function bud(d){this.a=d},
ava:function ava(d,e,f){this.c=d
this.d=e
this.a=f},
a0F:function a0F(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
aw7:function aw7(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
a2S:function a2S(){}},D,H,F,I,G,E
J=c[1]
B=c[0]
A=c[2]
C=a.updateHolder(c[6],C)
D=c[42]
H=c[11]
F=c[29]
I=c[32]
G=c[14]
E=c[38]
C.xX.prototype={
a_(){var x=B.b([],y.W)
return new C.Zs(A.a7,x,A.wT,A.T,null,null)}}
C.A9.prototype={}
C.Zs.prototype={
ga8H(){var x=this.gcD().cI(0,$.fS(),y.j)
x=x==null?null:x.a
return"heart_game_best_"+(x==null?"guest":x)},
au(){var x,w=this
w.aH()
w.IH()
x=w.zd(w.gaIV())
x.uM(0)
w.w!==$&&B.bf()
w.w=x},
IH(){var x=0,w=B.u(y.H),v,u=this,t
var $async$IH=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.kL(),$async$IH)
case 3:t=e
if(u.c==null){x=1
break}u.A(new C.bp_(u,t))
case 1:return B.r(v,w)}})
return B.t($async$IH,w)},
CM(){var x=0,w=B.u(y.H),v=this
var $async$CM=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.kL(),$async$CM)
case 3:x=2
return B.i(e.lp("Int",v.ga8H(),v.ax),$async$CM)
case 2:return B.r(null,w)}})
return B.t($async$CM,w)},
aIW(d){var x=this,w=(d.a-x.x.a)/1e6
x.x=d
if(!x.ay||x.ch)return
if(w<=0||w>0.25||x.CW.ga3(0))return
x.aFB(0,w)},
aFB(d,e){var x,w,v,u,t,s,r,q,p,o=this,n=A.e.dL(0.16+o.at*0.006,0.16,0.5),m=A.e.dL(1.25-o.at*0.02,0.55,1.25)
if((o.as+=e)>=m){o.as=0
o.z.push(new C.A9(1.05,0.12+o.Q.aim()*0.76))}for(x=o.z,w=x.length,v=n*e,u=0;u<w;++u){t=x[u]
t.a-=v}for(u=0;u<w;++u){t=x[u]
if(!t.c&&t.a<0.16){t.c=!0;++o.at}}A.b.eA(x,new C.bp1())
w=o.CW
s=w.a
r=w.b
w=Math.min(s,r)
for(v=x.length,w=(w*0.075+w*0.055)*0.8,u=0;u<x.length;x.length===v||(0,B.L)(x),++u){t=x[u]
q=(t.a-0.16)*s
p=(t.b-o.y)*r
if(Math.sqrt(q*q+p*p)<w){o.ch=!0
o.ay=!1
x=o.at
if(x>o.ax){o.ax=x
o.CM()}break}}if(o.c!=null)o.A(new C.bp2())},
aC1(d){var x=this
if(!x.ay||x.CW.b===0)return
x.A(new C.boZ(x,d))},
aaK(){this.A(new C.bp0(this))},
m(){var x=this.w
x===$&&B.a()
x.m()
this.asq()},
E(d){var x=this,w=null,v=x.gcD(),u=$.bSr(),t=v.bi(u.$1(x.a.d),y.x),s=v.bi($.k4(),y.B)
v.u1(u.$1(x.a.d),new C.bp5(d))
u=$.fn
return B.e9(B.fz(w,!0,A.G,w,w,0,A.l,w,w,B.ag(D.akw,A.k,A.h,A.O,0,w)),u,B.z4(!0,B.al(B.b([new C.asv(B.dc(t),w),A.an,new C.ava(x.at,x.ax,w),A.an,B.aC(new B.ap(F.Ez,B.fd(B.ab(24),B.vb(new C.bp6(x,s)),A.aD),w),1,w)],y.p),A.k,A.h,A.i,0,A.n),A.al,!0),w,!1,w)}}
C.aqm.prototype={
E(d){var x,w,v,u,t=this,s=null,r=t.e
if(r.ga3(0))return A.au
x=r.a
r=r.b
w=Math.min(x,r)*0.075
v=w*2
u=t.f
u=u!=null&&u.length!==0?B.hY(u,A.F,new C.bp7(t,v),A.eC,v,v):t.a4l(v)
return B.hf(s,u,s,s,t.d*x-w,s,t.c*r-w,s)},
a4l(d){var x=null,w=B.b([new B.bL(2,A.a5,B.S(153,D.x1.l()>>>16&255,D.x1.l()>>>8&255,D.x1.l()&255),A.o,16)],y.V)
return B.a7(x,B.ac(E.lK,A.l,x,x,d*0.6),A.j,x,x,new B.a9(x,x,x,x,w,D.au1,A.bj),x,d,x,x,x,x,x,d)}}
C.Md.prototype={
E(d){var x,w,v,u,t,s,r=this,q=null,p=r.d
if(p.ga3(0))return A.au
x=p.a
p=p.b
w=Math.min(x,p)*0.055
v=w*2
u=r.c
t=u.a
s=r.e
s=s!=null&&s.length!==0?B.hY(s,A.F,new C.btK(r,v),A.eC,v,v):r.a4m(v)
return B.hf(q,s,q,q,t*x-w,q,u.b*p-w,q)},
a4m(d){var x=null,w=B.bE(B.S(64,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),A.x,1.5),v=B.b([new B.bL(0,A.a5,B.S(A.e.a6(76.5),A.p.l()>>>16&255,A.p.l()>>>8&255,A.p.l()&255),A.o,8)],y.V)
return B.a7(x,B.ac(D.FT,B.S(217,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),x,x,d*0.55),A.j,x,x,new B.a9(A.DN,x,w,x,v,x,A.bj),x,d,x,x,x,x,x,d)}}
C.asv.prototype={
E(d){var x,w,v,u,t=null,s=this.c
if(s==null)return D.ayf
x=s.y
if(x===A.cZ)return B.a7(t,D.a3Z,A.j,t,t,new B.a9(B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),t,t,B.ab(14),t,t,A.q),t,t,t,A.dk,I.xI,t,t,t)
w=G.T7(x)
x=B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255)
v=B.ab(16)
s=s.CW
u=s===A.f6?A.ik:A.ii
u=B.b([new B.Ae(E.Fx,"\u0627\u0646\u062a\u0638\u0627\u0631",A.iN),new B.Ae(A.e3,"\u062a\u062d\u0636\u064a\u0631",A.hu),new B.Ae(u,"\u062c\u0627\u0647\u0632",A.dA)],y.K)
if(s===A.d_)u.push(new B.Ae(E.ow,"\u062a\u0648\u0635\u064a\u0644",A.f5))
u.push(new B.Ae(A.e2,"\u062a\u0633\u0644\u064a\u0645",A.cc))
s=new B.dC(u,y.Q)
return B.a7(t,B.ag(s.ges(s).dH(0,new C.bud(w),y.e).cM(0),A.k,A.dx,A.i,0,t),A.j,t,t,new B.a9(x,t,t,v,t,t,A.q),t,t,t,A.dk,A.fo,t,t,t)}}
C.ava.prototype={
E(d){var x=null
return new B.ap(A.dk,B.ag(B.b([B.aC(new C.a0F("\u0627\u0644\u0646\u0642\u0627\u0637",this.c,E.lK,D.DO,x),1,x),A.bv,B.aC(new C.a0F("\u0623\u0641\u0636\u0644 \u0646\u062a\u064a\u062c\u0629",this.d,D.Fv,F.iH,x),1,x)],y.p),A.k,A.h,A.i,0,x),x)}}
C.a0F.prototype={
E(d){var x=this,w=null,v=B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),u=B.ab(14)
return B.a7(w,B.ag(B.b([B.ac(x.e,x.f,w,w,18),A.az,B.n(""+x.d,w,w,w,w,B.w(w,w,A.l,w,w,w,w,w,w,w,w,16,w,w,A.w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),A.aG,B.aC(B.n(x.c,w,A.ap,w,w,B.w(w,w,A.aI,w,w,w,w,w,w,w,w,11,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),1,w)],y.p),A.k,A.h,A.i,0,w),A.j,w,w,new B.a9(v,w,w,u,w,w,A.q),w,w,w,w,A.fP,w,w,w)}}
C.aw7.prototype={
E(d){var x,w,v,u=this,t=null,s=B.S(140,A.p.l()>>>16&255,A.p.l()>>>8&255,A.p.l()&255),r=y.p,q=B.b([],r),p=u.c
if(p){x=B.S(51,A.dW.l()>>>16&255,A.dW.l()>>>8&255,A.dW.l()&255)
w=B.bE(A.dW,A.x,2)
v=u.d
w=B.b([B.a7(t,B.ac(D.FT,A.l,t,t,34),A.j,t,t,new B.a9(x,t,w,t,t,t,A.bj),t,64,t,t,t,t,t,64),A.dO,D.aGp,A.c6,B.n("\u0646\u0642\u0627\u0637\u0643: "+v,t,t,t,t,B.w(t,t,A.aI,t,t,t,t,t,t,t,t,15,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t)],r)
if(v>0&&v>=u.e)A.b.K(w,B.b([A.b0,B.ag(D.alc,A.k,A.h,A.O,0,t)],r))
A.b.K(q,w)}else A.b.K(q,B.b([B.ac(E.lK,B.bt(4294929309),t,t,56),A.dO,D.aGQ,A.c6,D.aFq],r))
q.push(A.Zv)
r=B.ac(p?A.FG:D.aey,t,t,t,t)
q.push(B.a95(r,B.n(p?"\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649":"\u0627\u0628\u062f\u0623 \u0627\u0644\u0644\u0639\u0628",t,t,t,t,t,t,t,t),u.f,B.hI(t,t,A.l,t,t,t,t,t,t,$.fn,t,t,D.a8s,t,new B.dv(B.ab(14),A.I),t,t,t,t,t)))
return B.bO4(0,B.a7(t,B.dz(B.al(q,A.k,A.h,A.O,0,A.n),t,t),A.j,s,t,t,t,t,t,t,t,t,t,t))}}
C.a2S.prototype={
m(){var x=this,w=x.cl$
if(w!=null)w.O(0,x.ghX())
x.cl$=null
x.ar()},
d0(){this.dP()
this.dA()
this.hY()}}
var z=a.updateTypes(["~(bF)","~(oz)","~()","C(A9)","Md(A9)"])
C.bp_.prototype={
$0(){var x=this.a,w=B.f9(J.aH(this.b.a,x.ga8H()))
return x.ax=w==null?0:w},
$S:0}
C.bp1.prototype={
$1(d){return d.a<-0.08},
$S:z+3}
C.bp2.prototype={
$0(){},
$S:0}
C.boZ.prototype={
$0(){var x=this.a
x.y=A.e.dL(x.y+this.b.d.b/x.CW.b,0.05,0.95)},
$S:0}
C.bp0.prototype={
$0(){var x=this.a
A.b.V(x.z)
x.as=x.at=0
x.y=0.5
x.ch=!1
x.ay=!0},
$S:0}
C.bp5.prototype={
$2(d,e){var x,w
if(d==null)x=null
else{w=B.dc(d)
x=w==null?null:w.y}w=B.dc(e)
if((w==null?null:w.y)===A.dA&&x!==A.dA)this.a.a2(y.q).f.d3(D.ayJ)},
$S:1063}
C.bp6.prototype={
$2(d,e){var x,w,v,u=null,t=this.a
t.CW=new B.H(e.b,e.d)
x=B.b([$.fn,$.eq,$.uc],y.O)
w=t.z
v=this.b
w=B.Q(new B.J(w,new C.bp3(t,v),B.U(w).h("J<1,d>")),y.l)
w.push(new C.aqm(t.y,0.16,t.CW,v.dx,u))
if(!t.ay)w.push(new C.aw7(t.ch,t.at,t.ax,t.gaOk(),u))
return B.d8(A.bD,B.a7(u,new B.e1(A.bw,u,A.bl,A.z,w,u),A.j,u,u,new B.a9(u,u,u,u,u,new B.cm(A.c1,A.ci,A.a4,x,u,u),A.q),u,u,u,u,u,u,u,u),A.A,!1,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,new C.bp4(t),u,u,u,u,u,t.gaC0())},
$S:244}
C.bp4.prototype={
$0(){var x=this.a
if(!x.ay)x.aaK()},
$S:0}
C.bp3.prototype={
$1(d){return new C.Md(d,this.a.CW,this.b.dy,null)},
$S:z+4}
C.bp7.prototype={
$3(d,e,f){return this.a.a4l(this.b)},
$S:59}
C.btK.prototype={
$3(d,e,f){return this.a.a4m(this.b)},
$S:59}
C.bud.prototype={
$1(d){var x,w=null,v=d.b,u=this.a,t=v.c,s=u>G.T7(t),r=u===G.T7(t)
if(s)x=A.a1
else x=r?A.l:B.S(A.e.a6(76.5),A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255)
u=r?B.S(38,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255):A.G
t=B.bE(x,A.x,r?2:1)
return B.aC(B.al(B.b([B.a7(w,B.ac(s?A.jN:v.a,x,w,w,14),A.j,w,w,new B.a9(u,w,t,w,w,w,A.bj),w,28,w,w,w,w,w,28),A.kJ,B.n(v.b,w,A.ap,w,w,B.w(w,w,x,w,w,w,w,w,w,w,w,9,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w)],y.p),A.k,A.h,A.O,0,A.n),1,w)},
$S:1064};(function aliases(){var x=C.a2S.prototype
x.asq=x.m})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=C.Zs.prototype,"gaIV","aIW",0)
x(v,"gaC0","aC1",1)
w(v,"gaOk","aaK",2)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.xX,B.uy)
w(C.A9,B.A)
w(C.a2S,B.ry)
w(C.Zs,C.a2S)
v(B.ku,[C.bp_,C.bp2,C.boZ,C.bp0,C.bp4])
v(B.hE,[C.bp1,C.bp3,C.bp7,C.btK,C.bud])
v(B.k6,[C.bp5,C.bp6])
v(B.a1,[C.aqm,C.Md,C.asv,C.ava,C.a0F,C.aw7])
x(C.a2S,B.hw)})()
B.nd(b.typeUniverse,JSON.parse('{"Md":{"a1":[],"d":[]},"xX":{"R":[],"d":[]},"Zs":{"X":["xX"]},"aqm":{"a1":[],"d":[]},"asv":{"a1":[],"d":[]},"ava":{"a1":[],"d":[]},"a0F":{"a1":[],"d":[]},"aw7":{"a1":[],"d":[]}}'))
var y=(function rtii(){var x=B.a4
return{x:x("bv<bg?>"),e:x("iT"),V:x("z<bL>"),O:x("z<I>"),K:x("z<+icon,label,status(ai,c,eH)>"),p:x("z<d>"),W:x("z<A9>"),Q:x("dC<+icon,label,status(ai,c,eH)>"),B:x("fk"),l:x("d"),q:x("tW"),j:x("cX?"),H:x("~")}})();(function constants(){var x=a.makeConstList
D.a_8=new B.P(!0,A.aI,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFX=new B.as("\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0637\u0644\u0628",null,D.a_8,null,null,null,null,null,null,null,null)
D.a3Z=new B.l_(A.F,null,null,D.aFX,null)
D.x1=new B.I(1,1,0.26666666666666666,0.5333333333333333,A.m)
D.DO=new B.I(1,1,0.4196078431372549,0.615686274509804,A.m)
D.a8s=new B.a3(24,12,24,12)
D.Fv=new B.ai(57900,"MaterialIcons",null,!1)
D.aey=new B.ai(58571,"MaterialIcons",null,!1)
D.FT=new B.ai(63047,"MaterialIcons",null,!1)
D.ag7=new B.cq(E.lK,20,null,null,null,null)
D.aGR=new B.as("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628",null,null,null,null,null,null,null,null,null,null)
D.akw=x([D.ag7,A.az,D.aGR],y.p)
D.afQ=new B.cq(D.Fv,18,F.iH,null,null,null)
D.aCg=new B.P(!0,F.iH,null,null,null,null,null,A.w,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGT=new B.as("\u0631\u0642\u0645 \u0642\u064a\u0627\u0633\u064a \u062c\u062f\u064a\u062f!",null,D.aCg,null,null,null,null,null,null,null,null)
D.alc=x([D.afQ,A.aG,D.aGT],y.p)
D.a4W=new B.I(1,0.8,0.06666666666666667,0.3333333333333333,A.m)
D.amN=x([D.DO,D.a4W],y.O)
D.au1=new H.vB(A.F,0.5,A.a4,null,0,D.amN,null,null)
D.ayf=new B.cU(null,64,null,null)
D.aGX=new B.as("\u0637\u0644\u0628\u0643 \u062c\u0627\u0647\u0632 \u0644\u0644\u0627\u0633\u062a\u0644\u0627\u0645!",null,null,null,null,null,null,null,null,null,null)
D.ayJ=new B.ft(D.aGX,A.a1,null,null,null,null,null,null,null,null,null,null,null,A.af,!1,null,null,null,A.z,null)
D.aFq=new B.as("\u0627\u0633\u062d\u0628 \u0644\u0623\u0639\u0644\u0649 \u0648\u0623\u0633\u0641\u0644 \u0644\u062a\u0641\u0627\u062f\u064a \u0627\u0644\u0639\u0642\u0628\u0627\u062a",null,D.a_8,null,null,null,null,null,null,null,null)
D.aBH=new B.P(!0,A.l,null,null,null,null,22,A.w,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGp=new B.as("\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629!",null,D.aBH,null,null,null,null,null,null,null,null)
D.aBo=new B.P(!0,A.l,null,null,null,null,20,A.w,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGQ=new B.as("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628 \u0645\u0646 \u0627\u0644\u0627\u0635\u0637\u062f\u0627\u0645",null,D.aBo,null,null,null,null,null,null,null,null)})()};
(a=>{a["/Rnqh72U4JorhXyQLvNfzeNxesE="]=a.current})($__dart_deferred_initializers__);